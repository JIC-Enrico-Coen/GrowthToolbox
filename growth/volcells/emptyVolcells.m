function vc = emptyVolcells()
    vc.vxs3d = zeros(0,3);
    vc.vxfe = zeros(0,1,'uint32');
    vc.vxbc = zeros(0,3);
    vc.edgevxs = zeros(0,2,'uint32');
    vc.edgefaces = cell(0,1);
    vc.facevxs = cell(0,1);
    vc.faceedges = cell(0,1);
    vc.polyfaces = cell(0,1);
    vc.polyfacesigns = cell(0,1);
    vc.atcornervxs = true(0,1);
    vc.onedgevxs = true(0,1);
    vc.surfacevxs = true(0,1);
    vc.surfaceedges = true(0,1);
    vc.surfacefaces = true(0,1);
    vc.surfacevolumes = true(0,1);
end

