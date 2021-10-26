function z = compareObs( x, y )
    xe = isempty(x);
    ye = isempty(y);
    if xe && ye
        z = ''; % 'BOTH EMPTY';
        return;
    end
    if xe && ~ye
        z = 'X IS EMPTY, Y IS NONEMPTY';
        return;
    end
    if ye && ~xe
        z = 'X IS NONEMPTY, Y IS EMPTY';
        return;
    end
    xc = class(x);
    yc = class(y);
    if ~strcmp(xc,yc)
        z = ['DIFFERENT CLASSES ', xc, ' AND ', yc];
        return;
    end
    xs = size(x);
    ys = size(y);
    if (length(xs) ~= length(ys))
        z = sprintf( 'DIFFERENT DIMENSIONS %d AND %d', ...
            length(xs), length(ys) );
        return;
    end
    if any(xs ~= ys)
        z = ['DIFFERENT SIZES ', sizeString(xs), ' AND ', sizeString(ys)];
        return;
    end
    if isnumeric(x)
        zi = find(x ~= y, 1);
        if reallyempty(zi)
            z = ''; % 'IDENTICAL NUMERICS';
        else
            z = sprintf('DIFFERENT NUMERICS AT ELEMENT %d', zi );
        end
        return;
    end
    if islogical(x)
        zi = find(x ~= y, 1);
        if reallyempty(zi)
            z = ''; % 'IDENTICAL LOGICALS';
        else
            z = sprintf('DIFFERENT LOGICALS AT ELEMENT %d', zi );
        end
        return;
    end
    if ischar(x)
        zi = find(x ~= y, 1);
        if reallyempty(zi)
            z = ''; % 'IDENTICAL CHARS';
        else
            z = sprintf('DIFFERENT CHARS AT ELEMENT %d', zi );
        end
        return;
    end
    if strcmp(xc,'function_handle')
        if numel(x)==1
            xc = char(x);
            yc = char(y);
            if ~strcmp( xc, yc )
                z = sprintf('DIFFERENT FUNCTION HANDLES %s AND %s', ...
                    xc, yc );
                return;
            end
            z = ''; % 'IDENTICAL FUNCTION HANDLES';
            return;
        end
        for i=1:length(x)
            xc = char(x(i));
            yc = char(y(i));
            if ~strcmp( xc, yc )
                z = sprintf('DIFFERENT FUNCTION HANDLES AT ELEMENT %d: %s AND %s', ...
                    i, xc, yc );
                return;
            end
        end
        z = ''; % 'IDENTICAL FUNCTION HANDLES';
        return;
    end
    if iscell(x)
        xs = reshape(x,1,[]);
        ys = reshape(y,1,[]);
        z = cell(1,0);
        zi = 0;
        for i=1:numel(x)
            zs = compareObs(xs{i},ys{i});
            if ~reallyempty(zs)
                zi = zi+1;
                z{zi} = zs;
            end
        end
        return;
    end
    if isstruct(x)
        if numel(x) > 1
            xs = reshape(x,1,[]);
            ys = reshape(y,1,[]);
            zi = 0;
            z = cell(1,0);            
            for i=1:numel(x)
                zs = compareObs(xs(i),ys(i));
                if ~reallyempty(zs)
                    zi = zi+1;
                    z{zi} = zs;
                end
            end
            return;
        end
        xf = sort(fieldnames(x));
        yf = sort(fieldnames(y));
        xminusy = setdiff(xf,yf);
        yminusx = setdiff(yf,xf);
        xsecty = intersect(xf,xf);
        z = struct();
        for i=1:length(xsecty)
            f = xsecty{i};
            zf = compareObs( x.(f), y.(f) );
            if ~reallyempty(zf)
                z.(f) = zf;
            end
        end
        for i=1:length(xminusy)
            f = xminusy{i};
            z.(f) = [ 'FIELD ', f, ' ONLY IN X' ];
        end
        for i=1:length(yminusx)
            f = yminusx{i};
            z.(f) = [ 'FIELD ', f, ' ONLY IN Y' ];
        end
        return;
    end
    z = ['UNKNOWN TYPES ', class(x), ' AND ', class(y)];
end

function e = reallyempty(z)
    e = isempty(z) ...
        || (isstruct(z) && isempty(fieldnames(z)));
end

function s = sizeString(xs)
    if isempty(xs)
        s = 'EMPTY';
    elseif length(xs)==1
        s = sprintf( '[%d]', xs );
    else
        s = [ sprintf( '[%d', xs(1) ), sprintf(',%d',xs(2:end)) ];
    end
end
