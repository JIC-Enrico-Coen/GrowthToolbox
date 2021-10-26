function txt = tailLogFile(SubmissionName)
%tailLogFile(SubmissionName)
%   Show the last 45 lines of the log file for a remote job.

    [~,txt] = executeRemote( sprintf( 'tail -n45 ''%s''', SubmissionName ), true );
end