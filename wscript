APPNAME = "gvrep"
VERSION = "0.1.0"


def options(opt):
    opt.load("yml2json", tooldir="waftools")


def configure(cnf):
    cnf.load("yml2json", tooldir="waftools")
    cnf.find_program("lsc", var="LSC")


def build(bld):
    bld(
        name="yml2json",
        features="conv2json",
        source=bld.path.ant_glob("**/*.yml"),
        in_source_tree=True,
    )
    bld(
        name="livescript",
        rule="${LSC} -co ../js ../live",
        source=bld.path.ant_glob("live/**/*.ls"),
    )


def dist(dst):
    dst.files = dst.path.ant_glob("""
        img/
        js/**/*.js
        _locales/**/*.json
        vendor/**/*.js
        LICENSE
        manifest.json
    """)
