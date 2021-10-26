function clearstopbutton( m )
    if isGFtboxMesh(m)
        if isempty( m.pictures )
            return;
        end
        handles = guidata( m.pictures(1) );
    else
        handles = m;
    end
    clearFlag( handles, 'stopButton' );
end
