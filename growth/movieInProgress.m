function mip = movieInProgress( m )
    mip = ~isempty(m) && ~isempty( m.globalProps.mov );
end