public class Cur {
    
    public Cur(){
        
    }
    public Account curAccount(String name)  //method to create account
        {
            Cur controller = new Cur();
            String cur11 = controller.currencyFormat('20000€');
            String cur21 = controller.currencyFormat('20000.1€');
            String cur31 = controller.currencyFormat('20000.12€');
            String cur41 = controller.currencyFormat('20000.123€');
            return null;
        }
        
        String currencyFormat(String value){
            return value;
        }
        
        
}