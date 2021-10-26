%WHOAMI	display user id and retrieve system properties
%
%	WHOAMI displays a long user id (LID) in the form
%
%	   %time|username|domain|hostname|osarch|osname|osver|MLver
%
%	WHOAMI optionally returns various system properties including
%	a short user id (SID), which only contains static information
%	about the current system
%	programmers can easily create their own IDs
%		
%SYNTAX
%-------------------------------------------------------------------------------
%	    WHOAMI;	shows LID in the command window
%	W = WHOAMI;	retrieves user/net/cpu IDs only
%	W = WHOAMI(X);	retrieves user/net/cpu IDs and system properties
%
%INPUT
%-------------------------------------------------------------------------------
% X	any number or character
%
%OUTPUT
%-------------------------------------------------------------------------------
% W	structure with contents according to calling syntax
%	selected fields
%	.sid		= short ID without time stamp
%	.lid		= long  ID with    time stamp
%	.res		= char array with all system information
%			  format: 'fieldname(s):  entry'
%	.(fld1:n)	= structures of single system properties
%			  format: .fieldname(s) = entry
%
%NOTE
%-------------------------------------------------------------------------------
%	- the JAVA engine must be loaded
%	- system properties are retrieved from java sources
%	  InetAddress
%	  NTSystem
%	  System	  
%
%EXAMPLE
%-------------------------------------------------------------------------------
%	whoami;
% %18-Jun-2008 13:47:52|us|USZ|ws-36362|x86|Windows XP|5.1|7.6.0.324.R2008a
%
%	w=whoami(1);
%	w.ip
% %	xxx.yyy.192.244
%	w.file
% %	 encoding: 'Cp1252'
% %	separator: '\'

% created:
%	us	01-Feb-1988 us@neurol.unizh.ch
% modified:
%	us	18-Jun-2008 13:47:52

%-------------------------------------------------------------------------------
function	p=whoami(varargin)

% program ID
		magic='WHOAMI';
		pver='18-Jun-2008 13:47:52';

% check JAVA
	if	~usejava('jvm')
		disp('WHOAMI> java engine not loaded');
	if	nargout
		p='';
	end
		return;
	end

% import java packages
		import	java.lang.*;
		import	com.sun.security.auth.module.*;
		import	java.net.*;

% create OS fields
		ostag={
%			p.(fieldname)	system.(property)
%			---------------------------------
			'osarch'	'os.arch'
			'osname'	'os.name'
			'osver'		'os.version'
		};

% create ID templates
% - change this if you want to create your own SID/LID
% - use p.(fieldname)
		iddel='|';
		idtag={
%		ID:	lid: long	sid:short	available fields
%		--------------------------------------------------------
			'runtime'	''		'magic'
			'name'		'name'		'WHOAMIver'
			'domain'	'domain'	'MLver'
			'host'		'host'		'runtime'
			'osarch'	'osrach'	'name'
			'osname'	'osname'	'domain'
			'osver'		''		'host'
			'MLver'		'MLver'		'ip'
			''		''		'osarch'
			''		''		'osname'
			''		''		'osver'
		};

		d=datestr(clock);
		v=regexprep(version,{'(',')',' '},{'','','.'});

% populate structure with system information
		p.magic=magic;
		p.([magic,'ver'])=pver;
		p.MLver=v;

		p.runtime=d;
		p.sid='';
		p.lid='';
% 		e=NTSystem;
% 		p.name=char(e.getName);
% 		p.domain=char(e.getDomain);

		e=InetAddress.getLocalHost();
		p.host=char(e.getHostName);
		p.ip=char(e.getHostAddress);


% create ID strings
		p=WHOAMI_mkid(p,iddel,idtag);

	if	~nargout
		disp(p.lid);
		clear p;
	end
	if	~nargin					||...
		~nargout
		return;
	end

		txt={};
		p.res=txt;
		w=warning('off');			%#ok
		e=System.getProperties.keys;
	while	e.hasNext
		id=e.nextElement;
		s=strread(char(id),'%s','delimiter','.');
		cp=char(System.getProperty(id));
		cp=WHOAMI_mkctrl(cp);
		sf=struct('type','.','subs',s);
		p=subsasgn(p,sf,cp);
		txt=[					%#ok
			txt
			{id,cp}
		];
	end
		warning(w);

		txt=sortrows(txt);
		tm=max(cellfun(@numel,txt(:,1)));
		fmt=sprintf('%%-%-d.%-ds: %%s',tm,tm);
		txt=cellfun(@(x,y) sprintf(fmt,x,y),txt(:,1),txt(:,2),'uni',false);
		p.res=char(txt);
end
%-------------------------------------------------------------------------------
function	p=WHOAMI_mkid(p,iddel,idtag)

		lid='%';
		sid='%';
	for	i=1:size(idtag)
	if	~isempty(idtag{i,1})
		lid=sprintf('%s%s%s',lid,p.(idtag{i,1}),iddel);
	end
	if	~isempty(idtag{i,2})
		sid=sprintf('%s%s%s',sid,p.(idtag{i,1}),iddel);
	end
	end
		p.lid=lid(1:end-1);
		p.sid=sid(1:end-1);
end
%-------------------------------------------------------------------------------
function	s=WHOAMI_mkctrl(s)

% replace non-printable characters

		ix=s<' ';
	if	any(ix)
		dp=s;
		dp(ix)='.';
		dp=cellstr(dp.');
		np=splitlines(sprintf('CTRL(%d)\n',s(ix)),'%s');
        np(end) = [];
		dp(ix)=np;
		s=cat(2,dp{:});
	end
end
