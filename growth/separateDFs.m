function [x,y,z] = separateDFs( dfs )
%[x,y,z] = separateDFs( dfs )

    xyz = mod( dfs-1, 3 );
    nodes = (dfs-xyz-1)/3 + 1;
    x = nodes( xyz==0 );
    y = nodes( xyz==1 );
    z = nodes( xyz==2 );
end
