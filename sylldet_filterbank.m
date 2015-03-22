function [FILTER_SPECS MAG_RESPONSE]=sylldet_filterbank(FS,varargin)
% get pitch of sounds in a batch
%

ripple=.1;
attenuation=30;
cf=[1e3:1e3:3e3];
bw=ones(1,3)*200;
stopband=ones(1,3)*200;
order=141;

nparams=length(varargin);

if mod(nparams,2)>0
	error('ephysPipeline:argChk','Parameters must be specified as parameter/value pairs!');
end

for i=1:2:nparams
	switch lower(varargin{i})
		case 'ripple'
			ripple=varargin{i+1};
		case 'attenuation'
			attenuation=varargin{i+1};
		case 'cf'
			cf=varargin{i+1};
		case 'bw'
			bw=varargin{i+1};
		case 'stopband'
			stopband=varargin{i+1};
		case 'order'
			order=varargin{i+1};
	end
end

for i=1:length(cf)
	
	passband1=cf(i)-bw(i)/2;
	passband2=cf(i)+bw(i)/2;

	stopband1=passband1-stopband(i);
	stopband2=passband2+stopband(i);

	%hd=fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',stopband1,passband1,...
	%	passband2,stopband2,attenuation,ripple,attenuation,FS);
	
	hd=fdesign.bandpass('N,Fst1,Fp1,Fp2,Fst2',order,stopband1,passband1,passband2,stopband2,FS);
	opts=designopts(hd,'equiripple');

	FILTER_SPECS(i)=design(hd,'equiripple',opts);
	[MAG_RESPONSE.amp(:,i) f]=freqz(FILTER_SPECS(i),[],FS);
end

MAG_RESPONSE.f=f;
