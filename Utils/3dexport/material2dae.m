function material2dae( xmlstack, material )
%material2dae( xmlstack, material )
%   Write a Material to an XML stream.

    beginxmlelement( xmlstack, 'effect', 'id', [material.id '-effect'] );
    beginxmlelement( xmlstack, 'profile_COMMON' );
    beginxmlelement( xmlstack, 'technique', 'sid', 'common' );
    beginxmlelement( xmlstack, 'phong' );
    xmlcolorprop( xmlstack, 'emission', floatstring([0 0 0 1]) );
    xmlcolorprop( xmlstack, 'ambient', floatstring([0 0 0 1]) );
    xmlcolorprop( xmlstack, 'diffuse', floatstring([material.facecolor material.facealpha]) );
    xmlcolorprop( xmlstack, 'specular', floatstring([0.5 0.5 0.5 1]) );
    xmlfloatprop( xmlstack, 'shininess', '50' );
    xmlfloatprop( xmlstack, 'index_of_refraction', '1' );
    xmlstack.popto( 'effect' );
end
