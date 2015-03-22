function sylldet_coef_tdtwrite(FIR,FILE,FORMAT)
%
%
%


% write FIR coefficients to a FILE

switch lower(FORMAT(1))
	case 'b'
		% binary
		
		fid=fopen(FILE,'wb');
		fwrite(fid,FIR,'double');
		fclose(fid);

	case 'a'

		% ascii

		if isvector(FIR)
			FIR=FIR(:);
		end

		save(FILE,'FIR','-ascii','-double');

	otherwise
end
