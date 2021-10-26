import javax.swing.*

%class foo {
%    int bar;
%    foo() { bar = 17; }
%};

J = JFrame('Hi');
L = JLabel('asdsa');
P = J.getContentPane;
P.add(L);
J.setSize(400,400);
J.setVisible(1);
