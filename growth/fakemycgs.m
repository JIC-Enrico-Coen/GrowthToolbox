function [x,flag,relres,iter,resvec] = fakemycgs(A,b,tol,maxit,callback,varargin)
%FAKEMYCGS   Same arguments and results as MYCGS, but does nothing.
%    Intended for timing tests of the rest of the program.

    x = zeros(size(b));
    flag = 0;
    relres = 0;
    iter = 0;
    resvec = norm(b);
end
