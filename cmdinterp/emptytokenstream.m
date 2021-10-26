function ts = emptytokenstream()
    ts.name = '';
    ts.fid = -1;
    ts.tokens = {};
    ts.curtok = 1;
    ts.curline = 0;
    ts.stack = struct( [] );
end
