function [ok]=close_logfile;

% Closes the logfile used to write useful messages during processing.

global logfile_fid write_logfile;

if(write_logfile)
   fclose(logfile_fid);
end
