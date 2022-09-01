function a = cell2matSpaced( c )
    for ci=1:length(c)
        c{ci} = [c{ci}; 0];
    end
    a = cell2mat( c );
end