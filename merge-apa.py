import json
import re

def str2apa(str):
    return re.search(r"apa(\d+)", str).group(1)

def merge_charge(file1, file2):
    # print(f"file1: {file1} for apa {str2apa(file1)}")
    with open(file1, 'r') as f1, open(file2, 'r') as f2:
        data1 = json.load(f1)
        data2 = json.load(f2)
    max_cluster_id = max(data1["cluster_id"])
    merged_data = {
        "eventNo": data1["eventNo"],
        "subRunNo": data1["subRunNo"],
        "runNo": data1["runNo"],
        "type": data1["type"],
        "geom": "sbnd", #data1["geom"],
        "cluster_id": data1["cluster_id"]+[id + max_cluster_id for id in data2["cluster_id"]],
        "apa": [str2apa(file1)]*len(data1["cluster_id"]) + [str2apa(file2)]*len(data2["cluster_id"]),
        "x": data1["x"]+data2["x"],
        "y": data1["y"]+data2["y"],
        "z": data1["z"]+data2["z"],
        "q": data1["q"]+data2["q"],
    }
    # print("points:", len(merged_data["apa"]))
    return merged_data

def merge_light(file1, file2):
    with open(file1, 'r') as f1, open(file2, 'r') as f2:
        data1 = json.load(f1)
        data2 = json.load(f2)
    max_cluster_id = max(data1["cluster_id"])
    merged_data = {
        "eventNo": data1["eventNo"],
        "subRunNo": data1["subRunNo"],
        "runNo": data1["runNo"],
        "geom": data1["geom"],
        "cluster_id": data1["cluster_id"]+[id + max_cluster_id for id in data2["cluster_id"]],
        "apa": [str2apa(file1)]*len(data1["cluster_id"]) + [str2apa(file2)]*len(data2["cluster_id"]),
        "op_nomatching_cluster_ids": data1["op_nomatching_cluster_ids"]+data2["op_nomatching_cluster_ids"],
        "op_peTotal": data1["op_peTotal"]+data2["op_peTotal"],
        "op_pes": data1["op_pes"]+data2["op_pes"],
        "op_pes_pred": data1["op_pes_pred"]+data2["op_pes_pred"],
        "op_t": data1["op_t"]+data2["op_t"],

    }
    return merged_data

if __name__ == "__main__":
    qfile1 = "data/1/1-img-apa0.json"
    qfile2 = "data/1/1-img-apa1.json"

    qdata = merge_charge(qfile1, qfile2)
    qfile = re.sub(r"-apa\d+", "", qfile1)
    with open(qfile, 'w') as f:
        json.dump(qdata, f)
    
    lfile1 = "data/1/1-op-apa0.json"
    lfile2 = "data/1/1-op-apa1.json"
    ldata = merge_light(lfile1, lfile2)
    lfile = re.sub(r"-apa\d+", "", lfile1)
    with open(lfile, 'w') as f:
        json.dump(ldata, f)