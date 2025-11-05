function [ok]=create_logfile(year,day,stream);

% Creates a logfile to write useful messgaes during processing.
global file_info par_info return_flag
global logfile_fid write_logfile
init_file_info
init_par_info

logfile_required=file_info.logfile_required;
name_logfile    =file_info.name_logfile;
dir_analysis    =file_info.dir_analysis;

% Create logfile for informational messages.

datestring=get_datestring(year,day);
logfile=[dir_analysis name_logfile stream '_' datestring '.log'];
logfile_fid=fopen(logfile,'a');
if (logfile_fid<0)
   message2(['*** Output error: cannot write logfile.'])
   write_logfile=0;
else
   message2(['*** Opening logfile: ' logfile])
   write_logfile=logfile_required;
end
