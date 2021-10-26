function vvlayer = deleteVVmgen( vvlayer, varargin )
%vvlayer = deleteVVmgen( vvlayer, name1, name2, ... )
%   Delete VV morphogens.  Named morphogens that do not exist are ignored.

    mgens = intersect( varargin, vvlayer.mgendict.indexToName );
    delindexes = zeros(1,length(mgens));
    for i=1:length(mgens)
        delindexes(i) = vvlayer.mgendict.nameToIndex.(mgens{i});
    end
%     newToOld = 1:length(vvlayer.mgendict.indexToName);
%     newToOld(delindexes) = [];
%     oldToNew = zeros(1,length(vvlayer.mgendict.indexToName));
%     oldToNew(newToOld) = 1:length(newToOld);
    vvlayer.mgens(:,delindexes) = [];
    
%     delreact = any( vvlayer.reactLeft(:,delindexes) ~= 0, 2 ) | any( vvlayer.reactRight(:,delindexes) ~= 0, 2 );
%     if any(delreact) && ~isempty(vvlayer.reactLeft)
%         vvlayer.reactLeft = vvlayer.reactLeft( ~delreact, ~delindexes );
%         vvlayer.reactRight = vvlayer.reactRight( ~delreact, ~delindexes );
%         vvlayer.reactLR(delreact) = [];
%         vvlayer.reactRL(delreact) = [];
%     end
    
    vvlayer.mgendict.indexToName(delindexes) = [];
    vvlayer.mgendict.nameToIndex = rmfield( vvlayer.mgendict.nameToIndex, mgens );
end
