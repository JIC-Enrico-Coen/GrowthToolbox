function result = TransformTensor()
    result = cell(6,6);
    tmi = TMIndex();
    for i=1:6
        for j=1:6
            result(i,j) = {''};
        end
    end
    for a=1:3
    for b=1:3
        i = tmi(a,b);
        for e=1:3
        for f=1:3
            j = tmi(e,f);
            s = result{i,j};
            if s
                c = '+';
            else
                c = '=';
            end
            result(i,j) = ...
                {sprintf( '%s %c M(%d,%d)*M(%d,%d)', s, c, a, e, b, f )};
        end
        end
    end
    end
    for a=1:3
        for b=1:3
            fprintf( 1, 'MV(%d,%d)%s;\n', a, b, result{a,b} );
        end
    end
    fprintf( 1, '\n' );
    for a=1:3
        for b=4:6
            fprintf( 1, 'MV(%d,%d)%s;\n', a, b, result{a,b} );
        end
    end
    fprintf( 1, '\n' );
    for a=4:6
        for b=1:3
            fprintf( 1, 'MV(%d,%d)%s;\n', a, b, result{a,b} );
        end
    end
    fprintf( 1, '\n' );
    for a=4:6
        for b=4:6
            fprintf( 1, 'MV(%d,%d)%s;\n', a, b, result{a,b} );
        end
    end
    return;



    result = cell(6,6);
    for i=1:6
        for j=1:6
            result(i,j) = {''};
        end
    end
    tmi = TMIndex();
    for a=1:3
    for b=1:3
    for c=1:3
    for d=1:3
        ij = tmi(a,b,c,d,:);
        for e=1:3
        for f=1:3
        for g=1:3
        for h=1:3
            kl = tmi(e,f,g,h,:);
            if kl(1)
                s = result{ij(1),ij(2)};
                result{ij(1),ij(2)} = ...
                    sprintf( '%s + J%d%d J%d%d J%d%d J%d%d D%d%d', ...
                    s, a, e, b, f, c, g, d, h, kl(:) );
            end
        end
        end
        end
        end
    end
    end
    end
    end
end
