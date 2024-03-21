local opflash_input_label = std.extVar('opflash_input_label');


local wc = import 'wirecell.jsonnet';
local g = import 'pgraph.jsonnet';

local data_params = import 'params.jsonnet';
local simu_params = import 'simparams.jsonnet';

local reality = 'data';
local params = if reality == 'data' then data_params else simu_params;


local tools_maker = import 'pgrapher/common/tools.jsonnet';
local tools = tools_maker(params);

local wcls_maker = import 'pgrapher/ui/wcls/nodes.jsonnet';
local wcls = wcls_maker(params, tools);

// Collect the WC/LS input converters for use below.  Make sure the
// "name" argument matches what is used in the FHiCL that loads this
// file.  In particular if there is no ":" in the inputer then name
// must be the emtpy string.
local wcls_input = {
  opflashes: g.pnode({
    type: 'wclsOpFlashSource',
    name: '',
    data: {
      art_tag: opflash_input_label,
    },
  }, nin=0, nout=1),

};

local tensor_dump = function(anode, aname) {
    // https://github.com/WireCell/wire-cell-toolkit/blob/master/aux/docs/tensor-data-model.org#tensor-archive-files
    local cs = g.pnode({
        type: "TensorFileSink",
        name: "tensorsink-"+aname,
        data: {
            outname: "tensor-apa-"+aname+".tar.gz",
            prefix: "opflash_",
            dump_mode: true,
        }
    }, nin=1, nout=0),
    ret: cs
}.ret;

local graph = g.pipeline([wcls_input.opflashes, tensor_dump(tools.anodes[0],"anode0")]);

local app = {
  type: 'Pgrapher',
  data: {
    edges: g.edges(graph),
  },
};

// Finally, the configuration sequence
g.uses(graph) + [app]
