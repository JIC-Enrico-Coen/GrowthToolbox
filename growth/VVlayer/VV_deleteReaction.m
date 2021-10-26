function vvlayer = VV_deleteReaction( vvlayer, delreact )
%vvlayer = VV_deleteReaction( vvlayer, delreact )
%   Delete reactions.  DELREACT is a vector of the indexes of the reactions
%   to delete.

    vvlayer.reactLeft(delreact,:) = [];
    vvlayer.reactRight(delreact,:) = [];
    vvlayer.reactLR(delreact) = [];
    vvlayer.reactRL(delreact) = [];
end
