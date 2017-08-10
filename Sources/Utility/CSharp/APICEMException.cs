namespace APICEM {
    public class Exception : System.Exception
    {
        public Exception() 
        { 

        }

        public Exception(string message) : base(message)
        { 

        }

        public Exception(string message, System.Exception inner) : base(message, inner) 
        { 

        }

        protected Exception(
            System.Runtime.Serialization.SerializationInfo info,
            System.Runtime.Serialization.StreamingContext context 
        ) : base( info, context ) 
        { 

        }
    }

    public class CallException : APICEM.Exception 
    {
        public string ErrorCode { get; set; }
        public string Detail { get; set; }

        public CallException() 
        { 

        }

        public CallException(string errorCode, string message, string detail) : base(message)
        { 
            this.ErrorCode = errorCode;
            this.Detail = detail;
        }

        public CallException(string errorCode, string message, string detail, System.Exception inner) : base(message, inner) 
        { 
            this.ErrorCode = errorCode;
            this.Detail = detail;
        }

        protected CallException(
            System.Runtime.Serialization.SerializationInfo info,
            System.Runtime.Serialization.StreamingContext context 
        ) : base( info, context ) 
        { 

        }
    }

    public class TaskException : APICEM.Exception
    {
        public string ErrorCode { get; set; }
        public string FailureReason { get; set; }

        public TaskException() 
        { 

        }

        public TaskException(string errorCode, string message, string failureReason) : base(message)
        { 
            this.ErrorCode = errorCode;
            this.FailureReason = failureReason;
        }

        public TaskException(string errorCode, string message, string failureReason, System.Exception inner) : base(message, inner) 
        { 
            this.ErrorCode = errorCode;
            this.FailureReason = failureReason;
        }

        protected TaskException(
            System.Runtime.Serialization.SerializationInfo info,
            System.Runtime.Serialization.StreamingContext context 
        ) : base( info, context ) 
        { 

        }        
    }
}