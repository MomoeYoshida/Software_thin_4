function [ok]= message(message_string);
% Writes a message to both the screen and a file (whose file id is specified via 
% the global variable logfile_fid

global logfile_fid

disp(message_string);

if(logfile_fid>0)
   fprintf(logfile_fid,  message_string);  
   fprintf(logfile_fid, '\n');
end

