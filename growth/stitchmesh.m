function [m,remapnodes] = stitchmesh( m, is, js )
%[m,remapnodes] = stitchmesh( m, is, js )
%   m contains only m.nodes and m.tricellvxs.
%   Make corresponding nodes in is and js identical.
%   remapnodes is set to the renumbering function: remapnodes(i) is the
%   index in the new m of node i of the original m.
%
%   The nodes being identified with each other will be moved to their
%   midpoint.
%
%   WARNING: All of the other 3D geometrical information will be
%   recalculated.
%
%   See also: mergenodesprox


    numnodes = size(m.nodes,1);
    nodemap = true(numnodes,1);
    nodemap(js) = false;
    if isfield( m, 'prismnodes' )
        ips = prismIndexes( is );
        jps = prismIndexes( js );
        m.prismnodes(ips,:) = (m.prismnodes(ips,:) + m.prismnodes(jps,:))/2;
        prismnodemap = true(size(m.prismnodes,1),1);
        prismnodemap(jps) = false;
        m.prismnodes = m.prismnodes( prismnodemap, : );
        if isfield( m, 'fixedDFmap' )
            m.fixedDFmap(ips,:) = m.fixedDFmap(ips,:) | m.fixedDFmap(jps,:);
        end
    end
    if isfield( m, 'morphogens' )
        m.morphogens = m.morphogens( nodemap, : );
        m.morphogenclamp = m.morphogenclamp( nodemap, : );
    end
    m.nodes(is,:) = (m.nodes(is,:) + m.nodes(js,:))/2;
    m.nodes = m.nodes( nodemap, : );
    remapnodes = int32(1:numnodes);
    sjs = sort(js);
    ji = 1;
    offset = 0;
    offsets = zeros(1,numnodes,'int32');
    for i=1:numnodes
        if (ji <= length(sjs)) && (i==sjs(ji))
            offset = offset+1;
            ji = ji+1;
        else
            offsets(i) = offset;
        end
    end
    offsets(js) = offsets(is);
    remapnodes(js) = is;
    remapnodes = remapnodes - offsets;
    m.tricellvxs = reshape( remapnodes( m.tricellvxs ), [], 3 );
        
    if isfield( m, 'celledges' )
        m = rmfield( m, {'celledges','edgecells','edgeends','nodecelledges'});
        m = setmeshgeomfromnodes( m );
        [ok,m] = validmesh(m);
    end
end

function pdfs = renumberPrismDFs( pnmap, pdfs )
    pdfmap = false( 3, length(pnmap) );
    pdfmap( :, pnmap ) = true;
    pdfmap = reshape( pdfmap, 1, [] );
  % pdfs = pdfs(pdfmap);
    pdfs(~pdfmap(pdfs)) = [];
end
