function m = stepinternalrotation( m )
%m = stepinternalrotation( m )

    m = addinternalrotation( m, m.globalProps.stepinternalrotation );
end
