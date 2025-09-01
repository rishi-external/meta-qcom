
# classes/parsedump.bbclass
python do_dump_parsed() {
    import os, json
    pn = d.getVar('PN')
    pv = d.getVar('PV')
    pr = d.getVar('PR')
    outbase = d.getVar('BUILDHISTORY_DIR') or os.path.join(d.getVar('TOPDIR'), 'buildhistory')
    outdir = os.path.join(outbase, 'parsed', pn)
    bb.utils.mkdirhier(outdir)

    # Choose what to dump (add/remove to taste)
    subset = {
        'PN': d.getVar('PN', expand=True),
        'PV': d.getVar('PV', expand=True),
        'PR': d.getVar('PR', expand=True),
        'BPN': d.getVar('BPN', expand=True),
        'WORKDIR': d.getVar('WORKDIR', expand=True),
        'S': d.getVar('S', expand=True),
        'B': d.getVar('B', expand=True),
        'LICENSE': d.getVar('LICENSE', expand=True),
        'LIC_FILES_CHKSUM': d.getVar('LIC_FILES_CHKSUM', expand=True),
        'SRC_URI': d.getVar('SRC_URI', expand=True),
        'SRCREV': d.getVar('SRCREV', expand=True),
        'BRANCH': d.getVar('BRANCH', expand=True),
        'DEPENDS': d.getVar('DEPENDS', expand=True),
        'PACKAGES': d.getVar('PACKAGES', expand=True),
        'INSANE_SKIP': d.getVar('INSANE_SKIP', expand=True),
    }

    # Also capture key package-specific values for every package the recipe emits
    for pkg in (d.getVar('PACKAGES') or '').split():
        for key in ('RDEPENDS', 'RRECOMMENDS', 'RSUGGESTS', 'RPROVIDES', 'RREPLACES',
                    'RCONFLICTS', 'FILES'):
            kval = f'{key}:{pkg}'
            subset[kval] = d.getVar(kval, expand=True) or ''

    # Write JSON (easier to diff with tools) and a simple .vars file
    base = f"{pn}-{pv}-{pr}"
    with open(os.path.join(outdir, base + ".json"), "w") as jf:
        json.dump(subset, jf, indent=2, sort_keys=True)

    with open(os.path.join(outdir, base + ".vars"), "w") as tf:
        for k in sorted(subset.keys()):
            v = subset[k] if subset[k] is not None else ''
            tf.write(f'{k}="{v}"\n')
}

# Run once per recipe after parsing/patching and before configure
addtask dump_parsed after do_patch before do_configure

# Ensure directory exists and avoid sstate churn; tweak to your preference
do_dump_parsed[dirs] = "${BUILDHISTORY_DIR}"
do_dump_parsed[nostamp] = "1"
