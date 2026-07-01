/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;
 
public class Payment {
 
    private String paymentId;
    private String summonsId;
    private String paymentMethod;  // ONLINE or OFFICE
    private double paymentAmount;
    private String bankCardNo;     // masked for display e.g. **** **** **** 1234
    private String cardExpiry;     // MM/YY
    private String cvv;            // not stored in DB, only used for validation
    private String status;         // PAID or PENDING_OFFICE
    private String paymentDate;
    private String createdAt;
 
    // ── Constructor Empty ──
    public Payment() {}
 
    // ── Constructor Full ──
    public Payment(String paymentId, String summonsId, String paymentMethod,
                   double paymentAmount, String bankCardNo, String cardExpiry,
                   String status, String paymentDate) {
        this.paymentId     = paymentId;
        this.summonsId     = summonsId;
        this.paymentMethod = paymentMethod;
        this.paymentAmount = paymentAmount;
        this.bankCardNo    = bankCardNo;
        this.cardExpiry    = cardExpiry;
        this.status        = status;
        this.paymentDate   = paymentDate;
    }
 
    // ── Getters ──
    public String getPaymentId()     { return paymentId; }
    public String getSummonsId()     { return summonsId; }
    public String getPaymentMethod() { return paymentMethod; }
    public double getPaymentAmount() { return paymentAmount; }
    public String getBankCardNo()    { return bankCardNo; }
    public String getCardExpiry()    { return cardExpiry; }
    public String getCvv()           { return cvv; }
    public String getStatus()        { return status; }
    public String getPaymentDate()   { return paymentDate; }
    public String getCreatedAt()     { return createdAt; }
 
    // ── Setters ──
    public void setPaymentId(String paymentId)         { this.paymentId = paymentId; }
    public void setSummonsId(String summonsId)         { this.summonsId = summonsId; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    public void setPaymentAmount(double paymentAmount) { this.paymentAmount = paymentAmount; }
    public void setBankCardNo(String bankCardNo)       { this.bankCardNo = bankCardNo; }
    public void setCardExpiry(String cardExpiry)       { this.cardExpiry = cardExpiry; }
    public void setCvv(String cvv)                     { this.cvv = cvv; }
    public void setStatus(String status)               { this.status = status; }
    public void setPaymentDate(String paymentDate)     { this.paymentDate = paymentDate; }
    public void setCreatedAt(String createdAt)         { this.createdAt = createdAt; }
 
    // ── Helper: mask card number for display ──
    // e.g. 1234567890123456 → **** **** **** 3456
    public String getMaskedCardNo() {
        if (bankCardNo == null || bankCardNo.length() < 4) return "****";
        String last4 = bankCardNo.substring(bankCardNo.length() - 4);
        return "**** **** **** " + last4;
    }
 
    @Override
    public String toString() {
        return "Payment{" +
               "paymentId='"     + paymentId     + '\'' +
               ", summonsId='"   + summonsId     + '\'' +
               ", method='"      + paymentMethod + '\'' +
               ", amount="       + paymentAmount +
               ", status='"      + status        + '\'' +
               '}';
    }
}
