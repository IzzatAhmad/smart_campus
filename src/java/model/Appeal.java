/*
 * Smart Campus - Appeal Model
 */
package model;

public class Appeal {

    private String appealId;
    private String summonsId;
    private String studentId;
    private String appealReason;
    private String status;          // PENDING, REASONABLE, MODERATELY_REASONABLE, UNREASONABLE
    private String clericalComment;
    private String reviewedBy;
    private String reviewedByName;  // for display
    private String appealDate;
    private String reviewedDate;
    private String createdAt;

    // ── Related fields for display ──
    private String offenseName;
    private String summonsType;
    private double amount;
    private String studentName;
    private String matricNo;

    // ── Constructor Empty ──
    public Appeal() {}

    // ── Getters ──
    public String getAppealId()       { return appealId; }
    public String getSummonsId()      { return summonsId; }
    public String getStudentId()      { return studentId; }
    public String getAppealReason()   { return appealReason; }
    public String getStatus()         { return status; }
    public String getClericalComment(){ return clericalComment; }
    public String getReviewedBy()     { return reviewedBy; }
    public String getReviewedByName() { return reviewedByName; }
    public String getAppealDate()     { return appealDate; }
    public String getReviewedDate()   { return reviewedDate; }
    public String getCreatedAt()      { return createdAt; }
    public String getOffenseName()    { return offenseName; }
    public String getSummonsType()    { return summonsType; }
    public double getAmount()         { return amount; }
    public String getStudentName()    { return studentName; }
    public String getMatricNo()       { return matricNo; }

    // ── Setters ──
    public void setAppealId(String appealId)             { this.appealId = appealId; }
    public void setSummonsId(String summonsId)           { this.summonsId = summonsId; }
    public void setStudentId(String studentId)           { this.studentId = studentId; }
    public void setAppealReason(String appealReason)     { this.appealReason = appealReason; }
    public void setStatus(String status)                 { this.status = status; }
    public void setClericalComment(String clericalComment){ this.clericalComment = clericalComment; }
    public void setReviewedBy(String reviewedBy)         { this.reviewedBy = reviewedBy; }
    public void setReviewedByName(String reviewedByName) { this.reviewedByName = reviewedByName; }
    public void setAppealDate(String appealDate)         { this.appealDate = appealDate; }
    public void setReviewedDate(String reviewedDate)     { this.reviewedDate = reviewedDate; }
    public void setCreatedAt(String createdAt)           { this.createdAt = createdAt; }
    public void setOffenseName(String offenseName)       { this.offenseName = offenseName; }
    public void setSummonsType(String summonsType)       { this.summonsType = summonsType; }
    public void setAmount(double amount)                 { this.amount = amount; }
    public void setStudentName(String studentName)       { this.studentName = studentName; }
    public void setMatricNo(String matricNo)             { this.matricNo = matricNo; }

    // ── Helper: get display label for status ──
    public String getStatusLabel() {
        if (status == null) return "-";
        switch (status) {
            case "PENDING":               return "Pending Review";
            case "REASONABLE":            return "Reasonable";
            case "MODERATELY_REASONABLE": return "Moderately Reasonable";
            case "UNREASONABLE":          return "Unreasonable";
            default:                      return status;
        }
    }

    // ── Helper: get CSS class for status ──
    public String getStatusClass() {
        if (status == null) return "";
        switch (status) {
            case "PENDING":               return "status-pending";
            case "REASONABLE":            return "status-approved";
            case "MODERATELY_REASONABLE": return "status-moderate";
            case "UNREASONABLE":          return "status-rejected";
            default:                      return "";
        }
    }
}
