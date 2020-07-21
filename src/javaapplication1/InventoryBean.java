/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package javaapplication1;

/**
 *
 * @author Tech Land
*/
public class InventoryBean {
    private int id;
    private String name;
    private int amount;
    private int supplier_id;
    public InventoryBean(int id, String name, int amount, int supplier_id) {
        this.id = id;
        this.name = name;
        this.amount = amount;
        this.supplier_id = supplier_id;
    }  

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getAmount() {
        return amount;
    }

    public void setAmount(int amount) {
        this.amount = amount;
    }

    public int getSupplierid() {
        return supplier_id;
    }

    public void setSupplierid(int supplier_id) {
        this.supplier_id = supplier_id;
    }
    
}
