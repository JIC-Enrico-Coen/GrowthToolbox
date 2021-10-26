function [x,flag,relres,iter,resvec] = mycgs(A,b,tol,tolmethod,maxit,maxtime,x0,verbose,callback,varargin)
%MYCGS   Conjugate Gradients Squared Method.
%   See CGS for the documentation.  This version behaves exactly the same
%   except that it eliminates some unnecessary code for options we never
%   use, adds a limit on the allowed wallclock time, and prints out an
%   indication of progress.

% mycgs assumed that before it was called, a message was written to the
% command window that was not terminated by a newline.  Hence neednewline
% is initially true.

if nargin < 8
    verbose = true;
end

if verbose, fprintf( 1, '%s: beginning.\n', mfilename() ); end

neednewline = true;
havecallback = (nargin >= 9) && ~isempty(callback);
useGPU = strcmp( class(A), 'gpuArray' );

if (nargin < 2)
   error('MATLAB:cgs:NotEnoughInputs', 'Not enough input arguments.');
end

% Check matrix and right hand side vector inputs have appropriate sizes
[m,n] = size(A);
if (m ~= n)
  error('MATLAB:mycgs:NonSquareMatrix', 'Matrix must be square.');
end
if ~isequal(size(b),[m,1])
  error('MATLAB:mycgs:RSHsizeMatchCoeffMatrix', ...
     ['Right hand side must be a column vector of' ...
     ' length %d to match the coefficient matrix.'],m);
end

% Assign default values to unspecified parameters
if (nargin < 3) || isempty(tol)
   tol = 1e-6;
end
if (nargin < 4) || isempty(maxit)
   maxit = min(n,20);
end

% Check for all zero right hand side vector => all zero solution
n2b = mynorm2(b);                      % Norm of rhs vector, b
if (n2b == 0)                       % if    rhs vector is all zeros
   x = zeros(n,1);                  % then  solution is all zeros
   flag = 0;                        % a valid solution has been obtained
   relres = 0;                      % the relative residual is actually 0/0
   iter = 0;                        % no iterations need be performed
   resvec = 0;                      % resvec(1) = mynorm2(b-A*x) = mynorm2(0)
   if (nargout < 2)
      myItermsg(mfilename(),tol,maxit,0,flag,iter,NaN);
   end
   if verbose
       if neednewline
           fprintf( 1, '\n' );
       end
       fprintf( 1, '%s returning: right hand side is zero.\n', mfilename() );
   end
   return
end

if ((nargin >= 7) && ~isempty(x0))
   if ~isequal(size(x0),[n,1])
      warning('MATLAB:cgs:WrongInitGuessSize', ...
         'Initial guess has length %d, problem size is %d.',numel(x0),n);
      x = zeros(n,1);
   else
      x = x0(:);
   end
else
   x = zeros(n,1);
end
if useGPU
    fprintf( 1, '%s: calling gpuArray.\n', mfilename() );
    x = gpuArray(x);
end

% Set up for the method
flag = 1;
xmin = x;                          % Iterate which has minimal residual so far
imin = 0;                          % Iteration at which xmin was computed
r = b - A*x;
normr = mynorm2(r);        % Norm of residual.

NORMERROR = strcmp(tolmethod, 'norm');
if NORMERROR
    tolb = tol * n2b;                  % Relative tolerance
    endcondition = normr <= tolb;
else
    tolb = tol * max(abs(b));                  % Relative tolerance
    endcondition = max(abs(r)) <= tolb;
end

if endcondition                 % Initial guess is a good enough solution
   flag = 0;
   relres = normr / n2b;
   iter = 0;
   resvec = normr;
   if (nargout < 2)
      myItermsg(mfilename(),tol,maxit,0,flag,iter,relres);
   end
   fprintf( 1, '%s returning: initial guess was close enough: normr %f, tolb %f.\n', ...
       mfilename(), normr, tolb );
   return
end

rt = r;                            % Shadow residual
resvec = zeros(maxit+1,1);         % Preallocate vector for norms of residuals
resvec(1) = normr;                 % resvec(1) = mynorm2(b-A*x0)
normrmin = normr;                  % Norm of residual from xmin
rho = 1;
stag = 0;                          % stagnation of the method

% loop over maxit iterations (unless convergence or failure)

startTime = clock();
elapsedTime = 0;
ETIMEFLAG = 20;
MAXRELRES = 1e8;
RELRESFLAG = 21;
MAXRELRESITERS = 100;
relerrcount = 0;
relerr = 0;

itersPerDot = 20;
dotsPerLine = 50;
itersPerLine = itersPerDot*dotsPerLine;
if verbose, fprintf( 1, '%s: performing up to %d iterations.\n', mfilename(), maxit ); end
for i = 1 : maxit
   rho1 = rho;
   rho = rt' * r;
   if (rho == 0) || isinf(rho)
      flag = 4;
      break
   end
   if i == 1
      u = r;
      p = u;
   else
      beta = rho / rho1;
      if (beta == 0) || isinf(beta)
         flag = 4;
         break
      end
      u = r + beta * q;
      p = u + beta * (q + beta * p);
   end
   ph1 = p;
   ph = ph1;
   vh = A*ph;
   rtvh = rt' * vh;
   if rtvh == 0
      flag = 4;
      break
   else
      alpha = rho / rtvh;
   end
   if isinf(alpha)
      flag = 4;
      break
   end
   if alpha == 0                    % stagnation of the method
      stag = 1;
   end
   q = u - alpha * vh;
   uh1 = u+q;
   uh = uh1;

   % Check for stagnation of the method
   if stag == 0
      stagtest = zeros(n,1);
      if useGPU
          stagtest = gpuArray(stagtest);
      end
      ind = (x ~= 0);
      stagtest(ind) = uh(ind) ./ x(ind);
      stagtest(~ind & uh ~= 0) = Inf;
      if abs(alpha)*mynormInf(stagtest) < eps
         stag = 1;
      end
   end

   x = x + alpha * uh;              % form the new iterate
   errvec = b - A*x;
   normr = mynorm2(errvec);
   
   resvec(i+1) = normr;

    if NORMERROR
        endcondition = normr <= tolb;
    else
        endcondition = max(abs(errvec)) <= tolb;
    end

   if endcondition                 % check for convergence
      flag = 0;
      iter = i;
      break
   end

   if stag == 1 % Stagnation
      flag = 3;
      break
   end

   if normr < normrmin              % update minimal norm quantities
      normrmin = normr;
      xmin = x;
      imin = i;
   end
   qh = A*uh;
   r = r - alpha * qh;

   if (havecallback && (mod(i,10)==0) && callback(varargin{:}))
      if verbose
          if neednewline
              fprintf( 1, '\n' );
          end
          fprintf( 1, 'mycgs: detected stop on iteration %d\n', i );
      end
      flag = 8;
      break;
   end
   
   relerr = normr / n2b;
   if mod(i,itersPerLine)==1
       if verbose, fprintf( 1, '%6.3g (%g/%g) ', relerr, normr, n2b ); end
       neednewline = true;
       if maxtime > 0
           elapsedTime = etime( clock(), startTime );
           if elapsedTime > maxtime
              if verbose,  fprintf( 1, 'mycgs: time %f exceeded limit on iteration %d\n', elapsedTime, i ); end
               flag = ETIMEFLAG;
               break;
           end
       end
   end
   if verbose && mod(i,itersPerDot)==0
       fprintf( 1, '.' );
       neednewline = mod(i,itersPerLine) ~= 0;
       if ~neednewline % really
           fprintf( 1, '\n' );
       end
   end
    if relerr > MAXRELRES
        relerrcount = relerrcount+1;
        if relerrcount > MAXRELRESITERS
            flag = RELRESFLAG;
            break;
        end
    else
        relerrcount = 0;
    end
end                                % for i = 1 : maxit
if verbose
    fprintf( 1, '%s: completed after %d iterations .\n', mfilename(), i );
    if neednewline
        fprintf( 1, ' %.3g\n', relerr );
    else
        fprintf( 1, '%6.3g\n', relerr );
    end
end

% returned solution is first with minimal residual
if flag == 0
   relres = normr / n2b;
elseif flag==RELRESFLAG
   x = xmin;
   iter = imin;
   relres = relerr;
else
   x = xmin;
   iter = imin;
   relres = normrmin / n2b;
end

% truncate the zeros from resvec
if flag <= 1 || flag == 3
   resvec = resvec(1:i+1);
else
   resvec = resvec(1:i);
end

% only display a message if the output flag is not used
if verbose && (nargout < 2)
   myItermsg(mfilename(),tol,maxit,i,flag,iter,relres);
end

if verbose, fprintf( 1, '%s: returning. flag %d relres %g, iter %d\n', mfilename, flag, relres, iter ); end
end

function n = mynormInf( v )
% Necessary because the gpuArray library does not have a norm() function.
    n = max( abs( v(:) ) );
    if ~isnumeric(n)
        n = gather(n);
    end
    n = full(n);
%   n = norm( v, inf );
end

function n = mynorm2( v )
% Necessary because the gpuArray library does not have a norm() function.
    n = sqrt( double( sum( v(:).^2 ))  );
    if ~isnumeric(n)
        n = gather(n);
    end
    n = full(n);
%   n = norm( v );
end

function os = myItermsg(itermeth,tol,maxitNOTUSED,i,flag,iter,relres)
% Copied and renamed from ...matlab/sparfun/private/
%ITERMSG   Displays the final message for iterative methods.
%   ITERMSG(ITERMETH,TOL,MAXIT,I,FLAG,ITER,RELRES)
%
%   See also BICG, BICGSTAB, BICGSTABL, CGS, GMRES, LSQR, MINRES, PCG, QMR,
%   SYMMLQ, TFQMR.

%   Copyright 1984-2010 The MathWorks, Inc. 
%   $Revision: 1.7.4.2 $ $Date: 2010/04/21 21:33:12 $

if flag == 0
    if iter == 0
        if isnan(relres)
            os = sprintf(['The right hand side vector is all zero so %s\n', ...
                'returned an all zero solution without iterating.'], itermeth);
        else
            os = sprintf(['The initial guess has relative residual %0.2g ', ...
                'which is within\nthe desired tolerance %0.2g so %s ', ...
                'returned it without iterating.'], relres, tol, itermeth);
        end
    else
        os = sprintf(['%s converged at %s to a solution with relative ', ...
            'residual %0.2g.'], itermeth, myGetIterationInfo(iter, true), ...
            relres);
    end
else
    switch flag
        case 1,
            ncnv = sprintf(['%s stopped at %s without converging to the ', ...
                'desired tolerance %0.2g\nbecause the maximum number ', ...
                'of iterations was reached.'], ...
                itermeth, myGetIterationInfo(i, true), tol);
        case 2,
            ncnv = sprintf(['%s stopped at %s without converging to the ', ...
                'desired tolerance %0.2g\nbecause the system ', ...
                'involving the preconditioner was ill conditioned.'], ...
                itermeth, myGetIterationInfo(i, true), tol);
        case 3,
            ncnv = sprintf(['%s stopped at %s without converging to the ', ...
                'desired tolerance %0.2g\nbecause the method stagnated.'], ...
                itermeth, myGetIterationInfo(i, true), tol);
        case 4,
            ncnv = sprintf(['%s stopped at %s without converging to the ', ...
                'desired tolerance %0.2g\nbecause a scalar quantity ', ...
                'became too small or too large to continue computing.'], ...
                itermeth, myGetIterationInfo(i, true), tol);
        case 5,
            ncnv = sprintf(['%s stopped at %s without converging to the ', ...
                'desired tolerance %0.2g\nbecause the preconditioner is ', ...
                'not symmetric positive definite.'], ...
                itermeth, myGetIterationInfo(i, true), tol);
    end
    retStr = sprintf('The iterate returned %s has relative residual %0.2g.', ...
        myGetIterationInfo(iter, false), relres);
    os = sprintf('%s\n%s', ncnv, retStr);
end
disp(os)
end

function itstr = myGetIterationInfo(it, verbose)
% Copied and renamed from ...matlab/sparfun/private/
if length(it) == 2 % gmres
    if verbose
        itstr = sprintf('outer iteration %d (inner iteration %d)', ...
            it(1), it(2));
    else
        itstr = sprintf('(number %d(%d))', it(1), it(2));
    end
elseif fix(it) ~= it % bicgstab
    if verbose
        itstr = sprintf('iteration %.1f', it);
    else
        itstr = sprintf('(number %.1f)', it);
    end
else
    if verbose
        itstr = sprintf('iteration %d', it);
    else
        itstr = sprintf('(number %d)', it);
    end
end
end
