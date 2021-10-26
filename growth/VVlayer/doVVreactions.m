function vvlayer = doVVreactions( vvlayer, dt )
    for i=1:size( vvlayer.reactionLeft, 1 )
        dm1 = prod( vvlayer.mgens( :, vvlayer.reactLeft(i,:) ), 2 ) * (vvlayer.reactrateLR(i) * dt);
        dm2 = prod( vvlayer.mgens( :, vvlayer.reactRight(i,:) ), 2 ) * (vvlayer.reactrateRL(i) * dt);
        delta = dm1-dm2;
        nz = delta ~= 0;
        delta = delta(nz);
        vvlayer.mgens( nz, vvlayer.reactLeft(i,:) ) = vvlayer.mgens( nz, vvlayer.reactLeft(i,:) ) - delta;
        vvlayer.mgens( nz, vvlayer.reactRight(i,:) ) = vvlayer.mgens( nz, vvlayer.reactRight(i,:) ) + delta;
    end
end
