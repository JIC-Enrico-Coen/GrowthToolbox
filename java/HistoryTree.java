import java.util.*;
import java.lang.*;
import java.io.Serializable;

public class HistoryTree implements Serializable {
    public HistoryTree parent;
    public Vector<HistoryTree> children;
    public int whichChildAmI;
    public TreeRelation relationToParent;
    public String nodeName;
    public int row, col;
    public HistoryTree() {
        whichChildAmI = 0;
        relationToParent = new TreeRelation();
        nodeName = new String("ROOT");
        children = new Vector<HistoryTree>(5,5);
        row = 1;
        col = 0;
    };
    public HistoryTree( char [] name ) {
        whichChildAmI = 0;
        relationToParent = new TreeRelation();
        nodeName = new String( name );
        children = new Vector<HistoryTree>(5,5);
        row = 0;
        col = 0;
    };
    public HistoryTree( String name ) {
        whichChildAmI = 0;
        relationToParent = new TreeRelation();
        nodeName = name;
        children = new Vector<HistoryTree>(5,5);
    };
    public HistoryTree newChild() {
        HistoryTree newnode = new HistoryTree();
        children.addElement( newnode );
        newnode.parent = this;
        newnode.whichChildAmI = children.size();
        newnode.nodeName = nodeName.concat( "-" );
        Integer i = new Integer(newnode.whichChildAmI);
        newnode.nodeName = newnode.nodeName.concat( i.toString() );
        return( newnode );
    }
    public HistoryTree getRoot() {
        HistoryTree root = this;
        while (root.parent != null) {
            root = root.parent;
        }
        return( root );
    }
    public String toString() {
        String result = relationToParent.toString();
        result = result.concat( nodeName );
        for (int i = 0; i < children.size(); i++) {
            result = result.concat( i==0 ? "[" : "," );
            result = result.concat( children.elementAt(i).toString() );
        }
        if (children.size() > 0) { result = result.concat( "]" ); }
        return( result );
    }
    public void findCoords() {
        if (parent==null) {
            findCoords( 0, 0, new Vector<Integer>() );
        } else {
            parent.findCoords();
        }
    }
    public int[] gridSize() {
        int result[] = new int[2];
        int height = 0;
        int width = 0;
        for (int i = 0; i < children.size(); ++i) {
            int[] c = children.elementAt( i ).gridSize();
            height += c[0];
            if (width < c[1]) { width = c[1]; }
        }
        if (height==0) { height = 1; }
        ++width;
        result[0] = height;
        result[1] = width;
        return( result );
    }
    public int[][][] makeGrid() {
        if (parent != null) {
            return( parent.makeGrid() );
        } else {
            int[] s = gridSize();
            int[][][] grid = new int[s[0]][s[1]][6];
            makeGrid( grid );
            return( grid );
        }
    }
    public void makeGrid( int[][][] grid ) {
        addToGrid( grid );
        for (int i = 0; i < children.size(); ++i) {
            children.elementAt(i).makeGrid( grid );
        }
    }
    public void addToGrid( int[][][] grid ) {
        grid[row][col][0] = 1;
        if (parent != null) { grid[row][col][4] = 1; }
        if (children.size() > 0) {
            grid[row][col][2] = 1;
        }
        if (children.size() > 1) {
            for (int i = 0; i < children.size(); ++i) {
                HistoryTree child = children.elementAt(i);
                grid[child.row][col][2] = 1;
            }
            int lastRow = children.lastElement().row;
            grid[row][col][3] = 1;
            for (int i = row+1; i < lastRow; ++i) {
                grid[i][col][1] = 1;
                grid[i][col][3] = 1;
            }
            grid[lastRow][col][1] = 1;
        }
    }
    public int findCoords( int rowguess, int colguess, Vector<Integer> taken ) {
        while ((rowguess < taken.size()) && (taken.elementAt(rowguess).intValue() <= colguess)) {
            ++rowguess;
        }
        if (children.size()==0) {
            row = rowguess;
            col = colguess;
            int row1 = taken.size();
            if (row1 <= row) {
                taken.setSize( row+1 );
            }
            taken.setElementAt( col, row );
        } else {
            int childcol = colguess+1;
            row = children.elementAt(0).findCoords( rowguess, childcol, taken );
            col = colguess;
            int childrowguess = row+1;
            for (int i = 1; i < children.size(); i++) {
                childrowguess = children.elementAt(i).findCoords( childrowguess, childcol, taken );
                ++childrowguess;
            }
            if (taken.size() <= childrowguess) {
                taken.setSize( childrowguess );
            }
            taken.setElementAt( col, row );
            for (int i = row+1; i < childrowguess; i++) {
                taken.setElementAt( col+1, i );
            }
        }
        return( row );
    }
    public HistoryTree findHistory( int r, int c ) {
        if (c==col) {
            return( (r==row) ? this : null );
        }
        if (c < col) { return( null ); }
        for (int i = 0; i < children.size(); ++i) {
            HistoryTree ci = children.elementAt( i );
            if (ci.row > r) { return( null ); }
            HistoryTree result = ci.findHistory( r, c );
            if (result != null) { return( result ); }
        }
        return( null );
    }
}


        