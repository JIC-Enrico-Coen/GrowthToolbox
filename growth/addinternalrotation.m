function m = addinternalrotation( m, angle )
%m = addinternalrotation( m, angle )

    m = setinternalrotation( m, m.globalProps.totalinternalrotation + angle );
end
