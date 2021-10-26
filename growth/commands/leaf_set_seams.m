function m = leaf_set_seams( m, f_seam_p )
%m = leaf_set_seams( m, f_seam_p )
%   Create seams between the nodes in a given set.
%
%   OBSOLETE: use leaf_addseam instead.
%
%   Arguments:
%       f_seam_p: an array giving a real number for every node.  Every edge
%                 joining nodes for both of which this value is greater
%                 than 0.5 will be made a seam edge.
%
%   See also: leaf_addseam.
%
%   Topics: Mesh editing, Seams.
    
    seamnodes=find(f_seam_p>0.5);
    % use m.edgeends, m.seams, m.nodes
    % find nodes to be included in seams
    % find edges joining the nodes
    jn=[];
    for i=1:length(m.edgeends)
        ind=intersect(seamnodes,m.edgeends(i,:));
        if length(ind)==2
            jn(end+1)=i;
        end
    end
    % set all seams
    m.seams=false(size(m.edgeends,1),1);
    m.seams(jn)=true;
end