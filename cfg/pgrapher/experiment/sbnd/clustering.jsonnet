local wc = import "wirecell.jsonnet";
local g = import "pgraph.jsonnet";
local f = import 'pgrapher/common/funcs.jsonnet';

function (bee_dir = "data")
{
    per_anode(anode) :: {
        // Note, the "sampler" must be unique to the "sampling".
        local bs_live = {
            type: "BlobSampler",
            name: "bs_live%d" % anode.data.ident,
            data: {
                // FIXME: if anode.data.ident == 0 ...
                time_offset: -1600 * wc.us,
                drift_speed: 1.101 * wc.mm / wc.us,
                strategy: [
                    "center",
                    "stepped",
                ],
                // extra: [".*"] // want all the extra
                extra: [] // no extra
            }},
        local bs_dead = {
            type: "BlobSampler",
            name: "bs_dead%d" % anode.data.ident,
            data: {
                strategy: [
                    "center",
                ],
                extra: [".*"] // want all the extra
            }},

        local ptb = g.pnode({
            type: "PointTreeBuilding",
            name: "ptb%d" % anode.data.ident,
            data:  {
                samplers: {
                    "3d": wc.tn(bs_live),
                    "dead": wc.tn(bs_dead),
                },
                multiplicity: 1,
                tags: ["live", "dead"],
            }
        }, nin=1, nout=1, uses=[bs_live, bs_dead]),

        local mabc = g.pnode({
            type: "MultiAlgBlobClustering",
            name: "mabc%d" % anode.data.ident,
            data:  {
                inpath: "pointtrees/%d",
                outpath: "pointtrees/%d",
                bee_dir: bee_dir, // "data/0/0",
                save_deadarea: false, 
                // bee_dir: "", // "data/0/0",
                dead_live_overlap_offset: 2,
            }
        }, nin=1, nout=1, uses=[]),

        ret: g.pipeline([ptb]),
    }.ret,
}