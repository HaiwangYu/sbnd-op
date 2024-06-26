local opflash0_input_label = std.extVar('opflash0_input_label');
local opflash1_input_label = std.extVar('opflash1_input_label');
local raw_input_label = std.extVar('raw_input_label');  // eg "daq"


local wc = import 'wirecell.jsonnet';
local g = import 'pgraph.jsonnet';

local data_params = import 'pgrapher/experiment/sbnd/params.jsonnet';
local simu_params = import 'pgrapher/experiment/sbnd/simparams.jsonnet';

local reality = 'data';
local params = if reality == 'data' then data_params else simu_params;


local tools_maker = import 'pgrapher/common/tools.jsonnet';
local tools_all = tools_maker(params);
local tools = tools_all {
    // anodes: [tools_all.anodes[0]],
};

local wcls_maker = import 'pgrapher/ui/wcls/nodes.jsonnet';
local wcls = wcls_maker(params, tools);

// Collect the WC/LS input converters for use below.  Make sure the
// "name" argument matches what is used in the FHiCL that loads this
// file.  In particular if there is no ":" in the inputer then name
// must be the emtpy string.
local wcls_input = {
  opflashes0: g.pnode({
    type: 'wclsOpFlashSource',
    name: 'tpc0',
    data: {
      art_tag: opflash0_input_label,
    },
  }, nin=0, nout=1),
  opflashes1: g.pnode({
    type: 'wclsOpFlashSource',
    name: 'tpc1',
    data: {
      art_tag: opflash1_input_label,
    },
  }, nin=0, nout=1),
  opflashes: [wcls_input.opflashes0, wcls_input.opflashes1],
  adc_digits: g.pnode({
    type: 'wclsRawFrameSource',
    name: '',
    data: {
      art_tag: raw_input_label,
      frame_tags: ['orig'],  // this is a WCT designator
      // nticks: params.daq.nticks,
    },
  }, nin=0, nout=1),
};

local opflash_sink = function(anode, aname) {
    // https://github.com/WireCell/wire-cell-toolkit/blob/master/aux/docs/tensor-data-model.org#tensor-archive-files
    local cs = g.pnode({
        type: "TensorFileSink",
        name: "opflash_sink-"+aname,
        data: {
            outname: "opflash_sink-apa-"+aname+".tar.gz",
            prefix: "opflash_",
            dump_mode: true,
        }
    }, nin=1, nout=0),
    ret: cs
}.ret;

// local graph = g.pipeline([wcls_input.opflashes[0], opflash_sink(tools.anodes[0],"anode0")]);

local chsel_pipes = [
  g.pnode({
    type: 'ChannelSelector',
    name: 'chsel%d' % n,
    data: {
      channels: std.range(5638 * n, 5638 * (n + 1) - 1),
      //tags: ['orig%d' % n], // traces tag
    },
  }, nin=1, nout=1)
  for n in std.range(0, std.length(tools.anodes) - 1)
];

local sp_maker = import 'pgrapher/experiment/sbnd/sp.jsonnet';
local sp = sp_maker(params, tools, { sparse: false });
local sp_pipes = [sp.make_sigproc(a) for a in tools.anodes];

local img = import 'pgrapher/experiment/sbnd/img.jsonnet';
local img_maker = img();
local img_pipes = [img_maker.per_anode(a) for a in tools.anodes];

local clus = import 'pgrapher/experiment/sbnd/clustering.jsonnet';
local clus_maker = clus();
local clus_pipes = [clus_maker.per_anode(a) for a in tools.anodes];

local magoutput = 'protodune-data-check.root';
local magnify = import 'pgrapher/experiment/sbnd/magnify-sinks.jsonnet';
local sinks = magnify(tools, magoutput);

local charge_pipe = [
    g.pipeline([
        chsel_pipes[n],
        // sinks.orig_pipe[n],
        // nf_pipes[n],
        // sinks.raw_pipe[n],
        sp_pipes[n],
        // sinks.decon_pipe[n],
        // sinks.threshold_pipe[n],
        // sinks.debug_pipe[n], // use_roi_debug_mode=true in sp.jsonnet
        img_pipes[n],
        clus_pipes[n],
        ],
        'charge_pipe_%d' % n)
    for n in std.range(0, std.length(tools.anodes) - 1)
];

local matching_pipe = [
    g.pnode({
        type: 'CLMatching',
        name: 'matching%d' % n,
        data: {
            anode: wc.tn(tools.anodes[n]),
        },
    }, nin=2, nout=1)
    for n in std.range(0, std.length(tools.anodes) - 1)
];

// prefix:
// opflash: "opflash_"
// clbundle: "clbundle_"
local ts_sink = function(name, prefix) {
    // https://github.com/WireCell/wire-cell-toolkit/blob/master/aux/docs/tensor-data-model.org#tensor-archive-files
    local cs = g.pnode({
        type: "TensorFileSink",
        name: "ts_sink-"+name,
        data: {
            outname: "ts-"+name+".tar.gz",
            prefix: prefix,
            dump_mode: true,
        }
    }, nin=1, nout=0),
    ret: cs
}.ret;

local cl_sinks = [
    ts_sink('clbundle%d' % n, 'clbundle_')
    for n in std.range(0, std.length(tools.anodes) - 1)
];

local matching_maker = function(light_pipe, charge_pipe, matching_pipe, outnode) {
    ret: g.intern(
        innodes=[charge_pipe],
        outnodes=[outnode],
        centernodes=[
            light_pipe,
            matching_pipe
        ],
        edges=[
            g.edge(charge_pipe, matching_pipe, 0, 0),
            g.edge(light_pipe, matching_pipe, 0, 1),
            g.edge(matching_pipe, outnode, 0, 0),
        ],
    )
}.ret;

local matching_pipes = [
    matching_maker(
        wcls_input.opflashes[n],
        charge_pipe[n],
        matching_pipe[n],
        cl_sinks[n])
    for n in std.range(0, std.length(tools.anodes) - 1)
];

local main_pipe = g.fan.fanout("FrameFanout", matching_pipes);
local graph = g.pipeline([wcls_input.adc_digits, main_pipe]);

local app = {
  type: 'Pgrapher',
  data: {
    edges: g.edges(graph),
  },
};

// Finally, the configuration sequence
g.uses(graph) + [app]
