function    m=leaf_deletepatch_from_morphogen_level(m,wound)
    %function    m=leaf_deletepatch_from_morphogen_level(m,wound)
    %
    %method for deleting a region of mesh specified by setting 
    %a morphogen (say 'wound') greater than 0.5.
    %The value of 'wound' specified for  
    %all the vertices of the patch to be deleted must be set
    % to greater than 0.5 (i.e. a patch is not specified by a single
    % vertex - there must be at least three)
%
%   Topics: Mesh editing.

    %
    %J. Andrew Bangham, 2008
    % Modified by RK 2009 Feb for elegance and efficiency.

%    ind=find(wound>0.5);
%    listcells=[];
%    for i=1:size(m.tricellvxs,1)
%        if length(intersect(m.tricellvxs(i,:),ind'))==3
%            listcells(end+1)=i;
%       end
%    end
    if isempty(m), return; end
    listcells = find( cellMapFromNodeMap( m, wound>0.5, 'all' ) );
    m = leaf_deletepatch( m, listcells );
end
