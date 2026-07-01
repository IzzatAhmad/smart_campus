/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

public class OffenseType {

    private String offenseId;
    private String offenseName;
    private String offenseCategory; // MISCONDUCT or VEHICLE
    private double amount;
    private String description;
    private String status;          // ACTIVE or INACTIVE
    private String createdBy;
    private String createdByName;
    private String createdAt;
    private String updatedAt;

    // ── Constructor Empty ──
    public OffenseType() {}

    // ── Constructor Full ──
    public OffenseType(String offenseId, String offenseName, String offenseCategory,
                       double amount, String description, String status,
                       String createdBy, String createdAt, String updatedAt) {
        this.offenseId       = offenseId;
        this.offenseName     = offenseName;
        this.offenseCategory = offenseCategory;
        this.amount          = amount;
        this.description     = description;
        this.status          = status;
        this.createdBy       = createdBy;
        this.createdAt       = createdAt;
        this.updatedAt       = updatedAt;
    }

    // ── Getters ──
    public String getOffenseId()       { return offenseId; }
    public String getOffenseName()     { return offenseName; }
    public String getOffenseCategory() { return offenseCategory; }
    public double getAmount()          { return amount; }
    public String getDescription()     { return description; }
    public String getStatus()          { return status; }
    public String getCreatedBy()       { return createdBy; }
    public String getCreatedAt()       { return createdAt; }
    public String getUpdatedAt()       { return updatedAt; }
    public String getCreatedByName()   { return createdByName; }

    // ── Setters ──
    public void setOffenseId(String offenseId)             { this.offenseId = offenseId; }
    public void setOffenseName(String offenseName)         { this.offenseName = offenseName; }
    public void setOffenseCategory(String offenseCategory) { this.offenseCategory = offenseCategory; }
    public void setAmount(double amount)                   { this.amount = amount; }
    public void setDescription(String description)         { this.description = description; }
    public void setStatus(String status)                   { this.status = status; }
    public void setCreatedBy(String createdBy)             { this.createdBy = createdBy; }
    public void setCreatedAt(String createdAt)             { this.createdAt = createdAt; }
    public void setUpdatedAt(String updatedAt)             { this.updatedAt = updatedAt; }
    public void setCreatedByName(String createdByName)     { this.createdByName = createdByName; }

    @Override
    public String toString() {
        return "OffenseType{" +
               "offenseId='"       + offenseId       + '\'' +
               ", offenseName='"   + offenseName     + '\'' +
               ", category='"      + offenseCategory + '\'' +
               ", amount="         + amount          +
               ", status='"        + status          + '\'' +
               '}';
    }


}