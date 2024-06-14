tableextension 50200 SalesReceivablesSetupExt extends "Sales & Receivables Setup"
{
    fields
    {
        field(50200; "Copy Cust Comments to Order"; Boolean)
        {
            Caption = 'Copy Comments from Customer to Order';
            InitValue = true;
        }
    }
}

pageextension 50200 SalesReceivablesSetupExt extends "Sales & Receivables Setup"
{
    layout
    {
        addbefore("Copy Comments Order to Invoice")
        {
            field("Copy Cust Comments to Order"; Rec."Copy Cust Comments to Order")
            {
                ApplicationArea = All;
                ToolTip = 'If this field is checked, the comments from the customer card will be copied to the sales order header.';
            }
        }
    }
}

tableextension 50201 SalesHeaderExt extends "Sales Header"
{
    fields
    {
        modify("Sell-to Customer No.")
        {
            trigger OnAfterValidate()
            begin
                if SalesReceivablesSetup.Get() then
                    if SalesReceivablesSetup."Copy Cust Comments to Order" then
                        CopyCommentsFromCustToSalesHeader();
            end;
        }
    }
    trigger OnAfterInsert()
    begin
        if SalesReceivablesSetup.Get() then
            if SalesReceivablesSetup."Copy Cust Comments to Order" then
                CopyCommentsFromCustToSalesHeader();
    end;

    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";

    local procedure CopyCommentsFromCustToSalesHeader()
    var
        CommentLine: Record "Comment Line";
        SalesCommentLine: Record "Sales Comment Line";
    begin
        if Rec."Sell-to Customer No." = '' then
            exit;
        SalesCommentLine.Reset();
        SalesCommentLine.SetRange("Document Type", Rec."Document Type");
        SalesCommentLine.SetRange("No.", Rec."No.");
        if SalesCommentLine.IsEmpty() then begin
            CommentLine.Reset();
            CommentLine.SetRange("Table Name", Enum::"Comment Line Table Name"::Customer);
            CommentLine.SetRange("No.", Rec."Sell-to Customer No.");
            if CommentLine.FindSet() then
                repeat
                    SalesCommentLine.Init();
                    SalesCommentLine."Document Type" := Rec."Document Type";
                    SalesCommentLine."No." := Rec."No.";
                    SalesCommentLine."Line No." := CommentLine."Line No.";
                    SalesCommentLine.Date := CommentLine.Date;
                    SalesCommentLine.Comment := CommentLine.Comment;
                    SalesCommentLine.Insert();
                until CommentLine.Next() = 0;
        end;
    end;
}
