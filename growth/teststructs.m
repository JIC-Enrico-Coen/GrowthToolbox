function teststructs()
%    profile on;
    x = test1();
    sum(x)
%    x = test1a();
%    sum(x)
    test4();
%    test3();
%    profile off;
end

function x = test1()
    x = zeros(10000,1);
    for i=1:10000
        x = x+1;
    end
end

function x = test1a()
    x = zeros(10000,1);
    for i=1:10000
        for j=1:10000
            x(j) = x(j)+1;
        end
    end
end

function test2()
    x = cell(10000,1);
    
    for i=1:10000
        x{i} = struct('foo',5);
    end
    for j=1:10
        for i=1:10000
            x{i}.foo = x{i}.foo+1;
        end
    end
end

function test3()
    x = struct( 'foo', zeros(10000,1) );
    x.foo = x.foo+1;
end

function test4()
    x = struct( 'foo', struct( 'bar', zeros(1,10) ) );
    x.foo.bar = x.foo.bar+1;
    x
    x.foo
    x.foo.bar
end
