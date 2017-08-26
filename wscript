APPNAME = "gvnavalrep"
VERSION = "0.1.0"


def options(opt):
    opt.load("yml2json", tooldir="waftools")


def configure(cnf):
    cnf.load("yml2json", tooldir="waftools")
    cnf.find_program("coffee", var="COFFEE")


def build(bld):
    bld(
        source=bld.path.ant_glob("**/*.yml"),
        in_source_tree=True,
    )
    bld(
        rule="${COFFEE} -bco ../js ../coffee",
        source=bld.path.ant_glob("coffee/**/*.coffee"),
    )


def dist(dst):
    dst.files = dst.path.ant_glob("""
        img/
        js/
        _locales/**/*.json
        LICENSE
        manifest.json
    """)
