/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author SHAHRUL
 */
public class PatrolStaff {
 
    private String patrolStaffId;
    private String patrolName;
    private String email;
    private String phoneNumber;
    private String password;
 
    // ── Constructor Empty ──
    public PatrolStaff() {}
 
    // ── Constructor Full ──
    public PatrolStaff(String patrolStaffId, String patrolName, String email,
                       String phoneNumber, String password) {
        this.patrolStaffId = patrolStaffId;
        this.patrolName    = patrolName;
        this.email         = email;
        this.phoneNumber   = phoneNumber;
        this.password      = password;
    }
 
    // ── Getters ──
    public String getPatrolStaffId() { return patrolStaffId; }
    public String getPatrolName()    { return patrolName; }
    public String getEmail()         { return email; }
    public String getPhoneNumber()   { return phoneNumber; }
    public String getPassword()      { return password; }
 
    // ── Setters ──
    public void setPatrolStaffId(String patrolStaffId) { this.patrolStaffId = patrolStaffId; }
    public void setPatrolName(String patrolName)       { this.patrolName = patrolName; }
    public void setEmail(String email)                 { this.email = email; }
    public void setPhoneNumber(String phoneNumber)     { this.phoneNumber = phoneNumber; }
    public void setPassword(String password)           { this.password = password; }
 
    @Override
    public String toString() {
        return "PatrolStaff{" +
               "patrolStaffId='" + patrolStaffId + '\'' +
               ", patrolName='"  + patrolName    + '\'' +
               ", email='"       + email         + '\'' +
               '}';
    }
}
