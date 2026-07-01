/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

public class ClericalStaff {
    private String clericalStaffId;
    private String clericalName;
    private String email;
    private String phoneNumber;
    private String password;

    public ClericalStaff() {}

    public ClericalStaff(String clericalStaffId, String clericalName, String email,
                         String phoneNumber, String password) {
        this.clericalStaffId = clericalStaffId;
        this.clericalName = clericalName;
        this.email = email;
        this.phoneNumber = phoneNumber;
        this.password = password;
    }

    public String getClericalStaffId() { return clericalStaffId; }
    public void setClericalStaffId(String clericalStaffId) { this.clericalStaffId = clericalStaffId; }

    public String getClericalName() { return clericalName; }
    public void setClericalName(String clericalName) { this.clericalName = clericalName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
}

