
python do_log_info() {
    import os

    # Get the top-level build directory
    topdir = d.getVar('TOPDIR')

    # Define the central log file path inside buildhistory
    log_file = os.path.join(topdir, 'buildhistory', 'recipe_log.txt')

    # Ensure the buildhistory directory exists
    if not os.path.exists(os.path.dirname(log_file)):
        os.makedirs(os.path.dirname(log_file))

    # Write log entry
    with open(log_file, 'a') as f:
        f.write(f"Logging from {d.getVar('FILE')}_{d.getVar('SRC_URI')}_{d.getVar('SRCREV')}\n")
}
do_log_info[nostamp] = "1"
addtask do_log_info after do_install before do_build
