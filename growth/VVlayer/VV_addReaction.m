function vvlayer = VV_addReaction( vvlayer, mgensleft, mgensright, rateLR, rateRL )
%vvlayer = addReaction( vvlayer, mgensleft, mgensright, rateLR, rateRL )
%   Add a reaction to the vvlayer.  mgensleft and mgensright are lists of
%   VV morphogens, and can be either cell arrays of morphogen names or
%   vectors of morphogen indexes.  rateLR and rateRL are the reaction rates
%   from left to right and right to left.

    mgensleft = lookUpVVmgens( vvlayer, mgensleft );
    mgensright = lookUpVVmgens( vvlayer, mgensright );
    reactL = zeros(1,size(vvlayer.mgens,2));
    reactR = reactL;
    reactL(mgensleft) = 1;
    reactR(mgensright) = 1;
    vvlayer.reactLeft = [ vvlayer.reactLeft; reactL ];
    vvlayer.reactRight = [ vvlayer.reactRight; reactR ];
    vvlayer.reactLR = rateLR;
    vvlayer.reactRL = rateRL;
end
