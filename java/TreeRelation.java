import java.util.*;
import java.lang.Integer;
import java.lang.String;
import java.io.Serializable;

public class TreeRelation implements Serializable {
    public int numSimSteps;
//  public TreeRelation( int n ) { numSimSteps = n; }
    public TreeRelation() { numSimSteps = 0; }
    public String toString() {
        String result = "(";
        result = result.concat( (new Integer( numSimSteps )).toString() );
        result = result.concat( ")" );
        return( result );
    }
}

