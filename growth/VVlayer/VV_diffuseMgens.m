function vvlayer = VV_diffuseMgens( vvlayer, dt )
    for i=1:size( vvlayer.diffusion, 1 )
        vvlayer = VV_diffuseMgen( vvlayer, i, dt );
    end
end

