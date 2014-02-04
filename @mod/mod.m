classdef mod < handle
   properties (Hidden)
      AccountStatus = 'open'; 
   end
   % The following properties can be set only by class methods
   properties (SetAccess = public)
      ac_voltage =0;
      paco=0;
      pdco=0;
      vdco=0;
      pso=0;
      c0=0;
      c1=0;
      c2=0;
      c3=0;
      pnt=0;
      vdcmax=0;
      idcmax=0;
      mppt_low=0;
      mppt_hi=0;
   end
%    end
%    % Define an event called InsufficientFunds
%    events
%       InsufficientFunds 
%    end
%    methods
%       function BA = BankAccount(AccountNumber,InitialBalance)
%          BA.AccountNumber = AccountNumber;
%          BA.AccountBalance = InitialBalance;
%          % Calling a static method requires the class name
%          % addAccount registers the InsufficientFunds listener on this instance
%          AccountManager.addAccount(BA);
%       end
%       function deposit(BA,amt)
%          BA.AccountBalance = BA.AccountBalance + amt;
%          if BA.AccountBalance > 0
%             BA.AccountStatus = 'open';
%          end
%       end
%       function withdraw(BA,amt)
%          if (strcmp(BA.AccountStatus,'closed')&& BA.AccountBalance < 0)
%             disp(['Account ',num2str(BA.AccountNumber),' has been closed.'])
%             return
%          end
%          newbal = BA.AccountBalance - amt;
%          BA.AccountBalance = newbal;
%          % If a withdrawal results in a negative balance,
%          % trigger the InsufficientFunds event using notify
%          if newbal < 0
%             notify(BA,'InsufficientFunds')
%          end
%       end % withdraw
%     end % methods
end % classdef