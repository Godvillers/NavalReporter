import json

from waflib         import Logs
from waflib.Task    import Task
from waflib.TaskGen import feature

import yaml


@feature("conv2json")
def convert_yaml_to_json(tgen):
    in_source_tree = getattr(tgen, "in_source_tree", False)
    untouched = [ ]
    for node in tgen.source:
        if node.suffix() in (".yml", ".yaml"):
            output = node.change_ext(".json")
            if in_source_tree:
                output = output.get_src()
            tgen.create_task("yml2json", node, output)
        else:
            untouched.append(node)

    tgen.source = untouched


class yml2json(Task):
    color = "YELLOW"

    def keyword(self):
        return "Converting"

    def run(self):
        try:
            with open(self.inputs[0].abspath(), encoding="utf-8-sig") as f:
                doc = yaml.safe_load(f)
            with open(self.outputs[0].abspath(), "w", encoding="utf-8") as f:
                json.dump(doc, f, sort_keys=True, ensure_ascii=False, separators=",:")
        except yaml.YAMLError as e:
            Logs.error(e)
            return 1
