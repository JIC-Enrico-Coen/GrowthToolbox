function newstate = toggleCheckedMenuItem( h )
    newstate = ~ischeckedMenuItem( h );
    checkMenuItem( h, newstate );
end
