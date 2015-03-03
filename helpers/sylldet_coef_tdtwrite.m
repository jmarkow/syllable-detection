function sylldet_coef_tdtwrite(FIR,FILE,FORMAT)
%
%
%


% write FIR coefficients to a FILE

switch lower(FORMAT(1))
	case 'b'
		% binary
		
		fid=fopen(FILE,'wb');

		for i=1:length(FIR)
			fwrite(fid,FIR,'double');
		end

		fclose(fid);

	case 'a'

		% ascii

		FIR=FIR(:);

		save(FILE,'FIR','-ascii','-double');

	otherwise
end
