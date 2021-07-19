public with sharing class Int_CalloutMock implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;

    private static final Integer DEFAULT_CODE = 200;
    private static final String DEFAULT_STATUS = 'OK';
    private static final String DEFAULT_BODY = '';

    public Int_CalloutMock(String nameObject, String method, String status) {

        if (method == 'Get') {
            if (nameObject == 'payment') {

                this.body = '[{"id":1,"uuid":"12b91c9d-db1b-11e9-9d96-a4bf011ce47b","type":"isr","bank_account":{"i' +
                        'd":1,"iban":"CH5409000000403390649"},"payment":{"instructed_amount":{"currency":"CHF","amount":' +
                        '3663.3},"recipient":{"name":"SVA Zürich","street":"Röntgenstrasse 17","house_number":"","zi' +
                        'p":"8087","city":"Zürich","country_code":"CH"},"execution_date":"2019-02-08","is_editing_restr' +
                        'icted":false,"bill_id":null,"account_number":"01-050507-1","isr_reference_nr":"000100904640014' +
                        '782370090112"},"instruction_id":"5c37afece9e773.73822643","status":"paid","created_at":"2019-0' +
                        '1-10T17:09:54+01:00"},{"id":2,"uuid":"12b922e3-db1b-11e9-9d96-a4bf011ce47b","type":"isr","bank_' +
                        'account":{"id":1,"iban":"CH5409000000403390649"},"payment":{"instructed_amount":{"currency":"C' +
                        'HF","amount":222.25},"recipient":{"name":"Salt Mobile SA","street":"Postfach","house_number":"","z' +
                        'ip":"1020","city":"Renens 1","country_code":"CH"},"execution_date":"2019-01-14","is_editing_re' +
                        'stricted":false,"bill_id":null,"account_number":"01-005292-2","isr_reference_nr":"000000000000' +
                        '000009013925018"},"instruction_id":"5c384d1f88b172.20680905","status":"paid","created_at":"201' +
                        '9-01-11T09:00:31+01:00"},{"id":7,"uuid":"12b92a1f-db1b-11e9-9d96-a4bf011ce47b","type":"iban","b' +
                        'ank_account":{"id":2,"iban":"CH2209000000917338062"},"payment":{"instructed_amount":{"currency":"E' +
                        'UR","amount":6307.5},"recipient":{"name":"WM Gruppe","street":"Düsseldorfer Strasse 16","house_n' +
                        'umber":"","zip":"60329","city":"Frankfurt am Main","country_code":"CH"},"execution_date":"2019-01-1' +
                        '4","is_editing_restricted":false,"bill_id":null,"iban":"DE97500800000090324300","message":"2056077' +
                        '7","is_salary_payment":false,"allowance_type":"fee_split"},"instruction_id":"5c3c34f78f74b8.3882410' +
                        '8","status":"cancelled","created_at":"2019-01-11T10:44:56+01:00"},{"id":8,"uuid":"12b92b27-db1b-11e' +
                        '9-9d96-a4bf011ce47b","type":"iban","bank_account":{"id":1,"iban":"CH5409000000403390649"},"payment":{"i' +
                        'nstructed_amount":{"currency":"CHF","amount":3803.6},"recipient":{"name":"Maria-Magdalena Soare Man' +
                        'escu","street":"Alte Bergstrasse 94","house_number":"","zip":"8707","city":"Uetikon am See","country_co' +
                        'de":"CH"},"execution_date":"2019-01-25","is_editing_restricted":false,"bill_id":null,"iban":"CH210483' +
                        '5019263361000","message":"Salär 1/2019","is_salary_payment":true,"allowance_type":"no_fee"},"instruct' +
                        'ion_id":"5c3871c87b0e49.45112698","status":"transmitted","created_at":"2019-01-11T11:36:57+01:00"},{"i' +
                        'd":9,"uuid":"12b92c1b-db1b-11e9-9d96-a4bf011ce47b","type":"iban","bank_account":{"id":1,"iban":"CH' +
                        '5409000000403390649"},"payment":{"instructed_amount":{"currency":"CHF","amount":8132.3},"recipient":{"n' +
                        'ame":"Balazs Kovacs","street":"Schiffbaustrasse 9a","house_number":"","zip":"8005","city":"Zürich","co' +
                        'untry_code":"CH"},"execution_date":"2019-01-25","is_editing_restricted":false,"bill_id":null,"iban":"CH' +
                        '0409000000318408976","message":"Salär 1/2019","is_salary_payment":true,"allowance_type":"no_fee"},"inst' +
                        'ruction_id":"5c3871c88c85e6.35296273","status":"transmitted","created_at":"2019-01-11T11:36:57+01:00"}]';

            } else if (nameObject == 'PDF') {

                this.body = '{"name":"2019-052.pdf","size":45684,"mime":"application/pdf","content":"JVBERi0xLjUKJeLjz9MKMSAwIG9iaiAK' +
                        'PDwKL0Zvcm1UeXBlIDEKL1N1YnR5cGUgL0Zvcm0KL1Jlc291cmNlcyAKPDwKL0ZvbnQgCjw8Ci9GMiAyIDAgUgovRjEgMyAwIFIKPj4KL1Byb2' +
                        'NTZXQgWy9QREYgL1RleHQgL0ltYWdlQiAvSW1hZ2VDIC9JbWFnZUldCi9YT2JqZWN0IAo8PAovTWV0YTExIDQgMCBSCj"}';

            } else if (nameObject == 'invoice') {

                this.body = '{"id":2,"document_nr":"RE-00002","title":"Solvency II Reporting for Aberdeen Standard (Q4 2020)","cont' +
                        'act_id":3,"contact_sub_id":null,"user_id":3,"project_id":null,"logopaper_id":1,"language_id":4,"bank_account_i' +
                        'd":1,"currency_id":3,"payment_type_id":4,"header":"","footer":"","total_gross":"250.000000","total_net":"250.0' +
                        '00000","total_taxes":"0.0000","total_received_payments":"0.000000","total_credit_vouchers":"0.000000","total_re' +
                        'maining_payments":"250.0000","total":"250.000000","total_rounding_difference":0,"mwst_type":2,"mwst_is_net":tru' +
                        'e,"show_position_taxes":false,"is_valid_from":"2020-12-01","is_valid_to":"2020-12-30","contact_address":"","kb_ite' +
                        'm_status_id":8,"reference":null,"api_reference":null,"viewed_by_client_at":null,"updated_at":"2021-02-24 15:57:0' +
                        '1","esr_id":2,"qr_invoice_id":2,"template_slug":"60365b8a81a24a1026294494","taxs":[],"network_link":""},{"id":4,"doc' +
                        'ument_nr":"RE-00004","title":"Solvency II Reporting for Aberdeen Standard (Q4 2020)","contact_id":5,"contact_sub_i' +
                        'd":null,"user_id":3,"project_id":null,"logopaper_id":1,"language_id":4,"bank_account_id":1,"currency_id":3,"payment_t' +
                        'ype_id":4,"header":"","footer":"","total_gross":"750.000000","total_net":"750.000000","total_taxes":"0.0000","total_r' +
                        'eceived_payments":"0.000000","total_credit_vouchers":"0.000000","total_remaining_payments":"750.0000","total":"750.00' +
                        '0000","total_rounding_difference":0,"mwst_type":2,"mwst_is_net":true,"show_position_taxes":false,"is_valid_from":"202' +
                        '1-02-24","is_valid_to":"2021-03-25","contact_address":"","kb_item_status_id":8,"reference":null,"api_reference":null,"v' +
                        'iewed_by_client_at":null,"updated_at":"2021-02-24 15:56:23","esr_id":4,"qr_invoice_id":4,"template_slug":"60365b8a81a2' +
                        '4a1026294494","taxs":[],"network_link":""}';

            } else if (nameObject == 'Invoice Product') {

                this.body = '{"id":1,"document_nr":"RE-00001","title":"Solvency II Reporting for Aberdeen Standard (Q4 2020)","contact_id":2,"cont' +
                        'act_sub_id":null,"user_id":3,"project_id":null,"logopaper_id":1,"language_id":4,"bank_account_id":1,"currency_id":3,"payme' +
                        'nt_type_id":4,"header":"","footer":"","total_gross":"1000.000000","total_net":"1000.000000","total_taxes":"0.0000","total_r' +
                        'eceived_payments":"1000.000000","total_credit_vouchers":"0.000000","total_remaining_payments":"0.0000","total":"1000.000000","t' +
                        'otal_rounding_difference":0,"mwst_type":2,"mwst_is_net":true,"show_position_taxes":false,"is_valid_from":"2021-02-24","is_vali' +
                        'd_to":"2021-03-25","contact_address":"","kb_item_status_id":9,"reference":null,"api_reference":null,"viewed_by_client_at":null,"u' +
                        'pdated_at":"2021-02-24 15:57:29","esr_id":1,"qr_invoice_id":1,"template_slug":"60365b8a81a24a1026294494","taxs":[],"positions":[{"i' +
                        'd":1,"type":"KbPositionCustom","amount":"4.000000","unit_id":null,"account_id":101,"unit_name":null,"tax_id":16,"tax_value":"7.70","t' +
                        'ext":"","unit_price":"250.000000","discount_in_percent":null,"position_total":"1000.000000","pos":"1","internal_pos":1,"parent_id":nu' +
                        'll,"is_optional":false}],"network_link":""}';

            } else if (nameObject == 'InvoiceUpdate') {
                System.debug(nameObject + '$$$$$$$$$$$$$$');

                this.body = '{"id":1,"document_nr":"2021-0215","title":"Solvency II Reporting for Aberdeen Standard (Q4 2020)","contact_id":2,"contact_sub_id":nul' +
                        'l,"user_id":3,"project_id":null,"logopaper_id":1,"language_id":4,"bank_account_id":1,"currency_id":3,"payment_type_id":4,"header":"","foo' +
                        'ter":"","total_gross":"1000.000000","total_net":"1000.000000","total_taxes":"0.0000","total_received_payments":"1000.000000","total_credit_vo' +
                        'uchers":"0.000000","total_remaining_payments":"0.0000","total":"1000.000000","total_rounding_difference":0,"mwst_type":2,"mwst_is_net":true,"s' +
                        'how_position_taxes":false,"is_valid_from":"2021-02-24","is_valid_to":"2021-03-25","contact_address":"","kb_item_status_id":9,"reference":null,"a' +
                        'pi_reference":null,"viewed_by_client_at":null,"updated_at":"2021-02-24 15:57:29","esr_id":1,"qr_invoice_id":1,"template_slug":"60365b8a81a24a1026' +
                        '294494","taxs":[],"positions":[{"i' +
                        'd":1,"type":"KbPositionCustom","amount":"4.000000","unit_id":null,"account_id":101,"unit_name":null,"tax_id":16,"tax_value":"7.70","t' +
                        'ext":"","unit_price":"250.000000","discount_in_percent":null,"position_total":"1000.000000","pos":"1","internal_pos":1,"parent_id":nu' +
                        'll,"is_optional":false}],"network_link":""}';

            } else if (nameObject == 'Update Invoice') {

                this.body = '{"id":1,"document_nr":"2021-0215","title":"Solvency II Reporting for Aberdeen Standard (Q4 2020)","contact_id":2,"contact_sub_id":nul' +
                        'l,"user_id":3,"project_id":null,"logopaper_id":1,"language_id":4,"bank_account_id":1,"currency_id":3,"payment_type_id":4,"header":"","foo' +
                        'ter":"","total_gross":"1000.000000","total_net":"1000.000000","total_taxes":"0.0000","total_received_payments":"1000.000000","total_credit_vo' +
                        'uchers":"0.000000","total_remaining_payments":"0.0000","total":"1000.000000","total_rounding_difference":0,"mwst_type":2,"mwst_is_net":true,"s' +
                        'how_position_taxes":false,"is_valid_from":"2021-02-24","is_valid_to":"2021-03-25","contact_address":"","kb_item_status_id":9,"reference":null,"a' +
                        'pi_reference":null,"viewed_by_client_at":null,"updated_at":"2021-02-24 15:57:29","esr_id":1,"qr_invoice_id":1,"template_slug":"60365b8a81a24a1026' +
                        '294494","taxs":[],"positions":[{"i' +
                        'd":1,"type":"KbPositionCustom","amount":"4.000000","unit_id":null,"account_id":101,"unit_name":null,"tax_id":16,"tax_value":"7.70","t' +
                        'ext":"","unit_price":"250.000000","discount_in_percent":null,"position_total":"1000.000000","pos":"1","internal_pos":1,"parent_id":nu' +
                        'll,"is_optional":false}],"network_link":""}';

            } else if (nameObject == 'paymentInvoice') {

                this.body = '[{"id":2694,"date":"2021-05-06","value":"450.000000","bank_account_id":7,"title":"payment receipt","payment_service_id":null,"is_client_accoun' +
                        't_redemption":false,"is_cash_discount":false,"kb_invoice_id":1,"kb_credit_voucher_id":null,"kb_bill_id":null,"kb_credit_voucher_text":""}]';

            } else {
                this.body = DEFAULT_BODY;
            }

        } else if (method == 'POST') {

            if (nameObject == 'UpdateInvoiceStatus') {

                this.body = '[{"id":1,"document_nr":"2021-106","title":"Solvency II Reporting for Aberdeen Standard (Q3, Q4 2020)","contact_id":169,"contact_sub_id":nu' +
                        'll,"user_id":4,"project_id":null,"logopaper_id":1,"language_id":4,"bank_account_id":10,"currency_id":3,"payment_type_id":4,"header":"Dear","foo' +
                        'ter":"Kind","total_gross":"3000.000000","total_net":"3000.000000","total_taxes":"0.0000","total_received_payments":"3000.000000","total_credit_v' +
                        'ouchers":"0.000000","total_remaining_payments":"0.0000","total":"3000.000000","total_rounding_difference":0,"mwst_type":2,"mwst_is_net":true,"sh' +
                        'ow_position_taxes":false,"is_valid_from":"2021-03-04","is_valid_to":"2021-04-02","contact_address":"Schroder","kb_item_status_id":9,"referenc' +
                        'e":"","api_reference":null,"viewed_by_client_at":null,"updated_at":"2021-04-12 11:57:04","esr_id":726,"qr_invoice_id":726,"template_slug":"5be162' +
                        'e603cf22f0418b461b","taxs":[],"network_link":""},{"id":2,"document_nr":"2021-131","title":"Regulatory Reporting (Q1 2021)","contact_id":46,"conta' +
                        'ct_sub_id":null,"user_id":1,"project_id":null,"logopaper_id":1,"language_id":1,"bank_account_id":1,"currency_id":1,"payment_type_id":1,"heade' +
                        'r":"Sehr","total_gross":"10000.000000","total_net":"10000.000000","total_taxes":"0.0000","total_received_payments":"0.000000","total_credit_vouc' +
                        'hers":"0.000000","total_remaining_payments":"10000.0000","total":"10000.000000","total_rounding_difference":0,"mwst_type":1,"mwst_is_net":true,"s' +
                        'how_position_taxes":false,"is_valid_from":"2021-04-12","is_valid_to":"2021-05-12","contact_address":"innova","kb_item_status_id":7,"referenc' +
                        'e":"","api_reference":"","viewed_by_client_at":null,"updated_at":"2021-04-12 09:46:32","esr_id":751,"qr_invoice_id":751,"template_slug":"5bcf29' +
                        '7b03cf2263508b465c","taxs":[],"network_link":""}]';
            } else if (nameObject == 'create Account') {

                this.body = '{"id":8,"nr":"000008","contact_type_id":1,"name_1":"Name","name_2":"Company","salutation_id":2,"salutation_form":null,"title_id":null,"birthda' +
                        'y":null,"address":"","postcode":"","city":"","country_id":1,"mail":"","mail_second":"","phone_fixed":"","phone_fixed_second":"","phone_mobile":"","f' +
                        'ax":"","url":"","skype_name":"","remarks":"","language_id":null,"is_lead":false,"contact_group_ids":null,"contact_branch_ids":null,"user_id":1,"owne' +
                        'r_id":1,"profile_image":"","updated_at":"2021-04-15 09:53:32"}';

            } else {
                this.body = DEFAULT_BODY;
            }
        }

        this.status = status != null ? status : DEFAULT_STATUS;
        this.code = DEFAULT_CODE;
    }

    public HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }
}