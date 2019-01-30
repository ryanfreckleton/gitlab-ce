interface Window {
    // Usage of jed
    translations: any;
    // Our u2f library:
    u2f: any;

    /**
     * Custom GitLab things
     */
    // emitSidebarEvent is a custom event we fire
    emitSidebarEvent: any;
    // activeVueResources tracks how many reqests are going on
    activeVueResources: any;
    // our global gl object
    gl: any;

}
