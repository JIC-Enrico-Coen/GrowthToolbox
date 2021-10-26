function uid = uniqueID( idprefix )
    uid = [ idprefix '-' char(java.util.UUID.randomUUID()) ];
end
